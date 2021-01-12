package Mojo::UserAgent::SecureServer;
use Mojo::Base 'Mojo::UserAgent::Server';

use Net::SSLeay ();
use Scalar::Util qw(weaken);

has listen => sub { Mojo::URL->new('https://127.0.0.1') };

sub from_ua {
  my $self   = ref $_[0] ? shift : shift->new;
  my $ua     = shift;
  my $server = $ua->server;

  $self->$_($server->$_) for qw(app ioloop);
  $self->listen->query->param($_ => $ua->$_) for grep { $ua->$_ } qw(ca cert key);
  $self->listen->query->param(verify => Net::SSLeay::VERIFY_PEER()) unless $ua->insecure;

  return $self;
}

sub nb_url { shift->_url(1, @_) }
sub url    { shift->_url(0, @_) }

sub _url {
  my ($self, $nb) = @_;

  unless ($self->{server}) {
    my $url = $self->listen->clone;

    # Blocking
    my $server = $self->{server} = Mojo::Server::Daemon->new(ioloop => $self->ioloop, silent => 1);
    weaken $server->app($self->app)->{app};
    $url->port($self->{port} || undef);
    $self->{port} = $server->listen([$url->to_string])->start->ports->[0];

    # Non-blocking
    $server = $self->{nb_server} = Mojo::Server::Daemon->new(silent => 1);
    weaken $server->app($self->app)->{app};
    $url->port($self->{nb_port} || undef);
    $self->{nb_port} = $server->listen([$url->to_string])->start->ports->[0];
  }

  my $port = $nb ? $self->{nb_port} : $self->{port};
  return Mojo::URL->new("https://127.0.0.1:$port/");
}

1;
