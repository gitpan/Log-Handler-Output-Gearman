package Log::Handler::Output::Gearman;

use strict;
use warnings;
use Carp;
use Gearman::XS::Client;
use Gearman::XS qw(:constants);
use Params::Validate;

our $VERSION = '0.01000_01';

=head1 NAME

Log::Handler::Output::Gearman - Send log messages to Gearman workers.

=head1 SYNOPSIS

    use Log::Handler::Output::Gearman;

    my $logger = Log::Handler::Output::Gearman->new(
        host   => '127.0.0.1',
        worker => 'logger',
    );

    my $message = 'This is a log message';
    $logger->log( $message );

=head1 DESCRIPTION

B<This is experimental ( beta ) and should only be used in a test environment. The
API may change at any time without prior notification until this message is removed!>

=head1 METHODS

=head2 new

Takes a number of arguments, following are B<mandatory>:

=over 4

=item *

host

    host => '127.0.0.1' # hostname / ip-address the B<gearmand> is running on

=item *

worker

    worker => 'logger' # name of the worker that should process the log messages

=back

Besides it takes also following B<optional> arguments:

=over 4

=item *

port (default: 4730)

    port => 4731 # port germand is listening to

=item *

method (default: do_background)

    method => 'do_high_background'

This can be one of the following L<Gearman::XS::Client> methods:

=over 4

=item * C<do>

=item * C<do_high>

=item * C<do_low>

=item * C<do_background>

=item * C<do_high_background>

=item * C<do_low_background>

=back

=back

=cut

sub new {
    my $package = shift;

    my %options = Params::Validate::validate(
        @_,
        {
            host => {
                type     => Params::Validate::SCALAR,
                optional => 0,
            },
            port => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^\d+$/,
                default => 4730,
            },
            worker => {
                type     => Params::Validate::SCALAR,
                optional => 0,
            },
            method => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^(do|do_high|do_low|do_background|do_high_background|do_low_background)$/,
                default => 'do_background',
            },
        }
    );

    my $self = bless \%options, $package;

    $self->_setup_gearman;

    return $self;
}

=head2 log

Takes two arguments of which the second is optional:

=over 4

=item *

C<$message> - The log message

=item *

C<$options> - Options to override default behaviour per log message

By default every log message is added to Gearman using C<do_background>. This default behaviour can be changed
on instantiation by setting C<method => '...'>. In case you need to send single messages with higher
priority you can override this per message:

    my $message = 'This is a HIGH PRIO log message';
    my $options = { method => 'do_high_background' };
    $logger->log( $message, $options );

It's also possible to send single messages to other workers:

    my $message = 'This is a HIGH PRIO log message';
    my $options = { method => 'do_high_background', worker => 'some_other_worker' };
    $logger->log( $message, $options );

=back

=cut

sub log {
    my ( $self, $message, $options ) = @_;

    return unless defined $message;

    $options ||= {};

    my $method = $options->{method} || $self->{method};
    my $worker = $options->{worker} || $self->{worker};

    my ( $ret, $job_handle ) = $self->{client}->$method( $worker, $message );
    if ( $ret != GEARMAN_SUCCESS ) {
        croak( $self->{client}->error() );
    }

    return 1;
}

sub _setup_gearman {
    my ($self) = @_;
    my $client = Gearman::XS::Client->new;
    my $ret = $client->add_server( $self->{host}, $self->{port} );
    if ( $ret != GEARMAN_SUCCESS ) {
        croak( $client->error() );
    }
    $self->{client} = $client;
}

=head1 AUTHOR

Johannes Plunien E<lt>plu@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by Johannes Plunien

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4 

=item * L<Log::Handler>

=item * L<Gearman::XS::Client>

=item * L<http://www.gearman.org/>

=back

=head1 REPOSITORY

L<http://github.com/plu/log-handler-output-gearman/>

=cut

1;
