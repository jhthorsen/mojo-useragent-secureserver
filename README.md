# NAME

Mojo::UserAgent::SecureServer - Secure application server for Mojo::UserAgent

# SYNOPSIS

    # Construct from Mojo::UserAgent
    my $ua = Mojo::UserAgent->new;
    $ua->ca('ca.pem')->cert('cert.pem')->key('key.pem');
    $ua->server(Mojo::UserAgent::SecureServer->from_ua($ua));

    # Construct manually
    my $ua     = Mojo::UserAgent->new;
    my $server = Mojo::UserAgent::SecureServer->new;
    $server->listen(Mojo::URL->new('https://127.0.0.1?cert=/x/server.crt&key=/y/server.key&ca=/z/ca.crt'));
    $ua->server($server);

    # Test::Mojo
    my $app = Mojolicious->new;
    $app->routes->get('/' => sub {
      my $c      = shift;
      my $handle = Mojo::IOLoop->stream($c->tx->connection)->handle;
      $c->render(json => {cn => $handle->peer_certificate('cn')});
    });

    my $t = Test::Mojo->new($app);
    $t->ua->insecure(0);
    $t->ua->ca('t/pki/certs/ca-chain.cert.pem')
      ->cert('t/pki/mojo.example.com.cert.pem')
      ->key('t/pki/mojo.example.com.key.pem');
    $t->ua->server(Mojo::UserAgent::SecureServer->from_ua($t->ua));

    $t->get_ok('/')->status_is(200)->json_is('/cn', 'mojo.example.com');

# DESCRIPTION

[Mojo::UserAgent::SecureServer](https://metacpan.org/pod/Mojo%3A%3AUserAgent%3A%3ASecureServer) allows you to test your [Mojolicious](https://metacpan.org/pod/Mojolicious) web
application with custom SSL/TLS key/cert/ca.

# ATTRIBUTES

[Mojo::UserAgent::SecureServer](https://metacpan.org/pod/Mojo%3A%3AUserAgent%3A%3ASecureServer) inherits all attributes from
[Mojo::UserAgent::Server](https://metacpan.org/pod/Mojo%3A%3AUserAgent%3A%3AServer) and implements the following new ones.

## listen

    $url = $server->listen;
    $server = $server->listen(Mojo::URL->new('https://127.0.0.1'));

The base listen URL for [Mojo::Server::Daemon](https://metacpan.org/pod/Mojo%3A%3AServer%3A%3ADaemon) created by ["nb\_url"](#nb_url) and
["url"](#url). The "port" will be discarded, while other
["listen" in Mojo::Server::Daemon](https://metacpan.org/pod/Mojo%3A%3AServer%3A%3ADaemon#listen) parameters are kept.

# METHODS

[Mojo::UserAgent::SecureServer](https://metacpan.org/pod/Mojo%3A%3AUserAgent%3A%3ASecureServer) inherits all methods from
[Mojo::UserAgent::Server](https://metacpan.org/pod/Mojo%3A%3AUserAgent%3A%3AServer) and implements the following new ones.

## from\_ua

    $server = Mojo::UserAgent::SecureServer->from_ua($ua);
    $server = $server->from_ua($ua);

Used to construct a new object and/or copy attributes from a [Mojo::UserAgent](https://metacpan.org/pod/Mojo%3A%3AUserAgent)
object. Here is the long version:

    $server->app($ua->server->app);
    $server->ioloop($ua->server->ioloop);
    $server->listen->query->param(ca     => $ua->ca);
    $server->listen->query->param(cert   => $ua->cert);
    $server->listen->query->param(key    => $ua->key);
    $server->listen->query->param(verify => Net::SSLeay::VERIFY_PEER()) unless $ua->insecure

## nb\_url

    $url = $server->nb_url;

Get absolute [Mojo::URL](https://metacpan.org/pod/Mojo%3A%3AURL) object for server processing non-blocking requests
with ["app" in Mojo::UserAgent::Server](https://metacpan.org/pod/Mojo%3A%3AUserAgent%3A%3AServer#app).

## url

    $url = $server->url;

Get absolute [Mojo::URL](https://metacpan.org/pod/Mojo%3A%3AURL) object for server processing non-blocking requests
with ["app" in Mojo::UserAgent::Server](https://metacpan.org/pod/Mojo%3A%3AUserAgent%3A%3AServer#app).

# AUTHOR

Jan Henning Thorsen

# COPYRIGHT AND LICENSE

Copyright (C) Jan Henning Thorsen.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

# SEE ALSO

[Mojo::UserAgent](https://metacpan.org/pod/Mojo%3A%3AUserAgent), [Mojo::UserAgent::Server](https://metacpan.org/pod/Mojo%3A%3AUserAgent%3A%3AServer) and [Test::Mojo](https://metacpan.org/pod/Test%3A%3AMojo).
