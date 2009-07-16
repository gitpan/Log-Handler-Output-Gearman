use strict;
use warnings;
use Log::Handler;
use Log::Handler::Output::Gearman;
use Test::More tests => 7;

eval { my $logger = Log::Handler::Output::Gearman->new(); };

like(
    $@,
    qr/Mandatory parameters 'worker', 'servers' missing in call to Log::Handler::Output::Gearman::new/,
    'Mandatory parameters missing'
);

eval { my $logger = Log::Handler::Output::Gearman->new( method => 'invalid' ); };

like(
    $@,
    qr/The 'method' parameter \("invalid"\) to Log::Handler::Output::Gearman::new did not pass regex check/,
    'Invalid Gearman::XS::Client method'
);

eval { my $logger = Log::Handler::Output::Gearman->new( servers => 'invalid' ); };

like(
    $@,
qr/The 'servers' parameter \("invalid"\) to Log::Handler::Output::Gearman::new was a 'scalar', which is not one of the allowed types: arrayref/,
    'Invalid servers parameter'
);

eval {
    my $logger = Log::Handler::Output::Gearman->new(
        servers         => ['127.0.0.1:1234'],
        worker          => 'logger',
        prepare_message => 'invalid'
    );
};

like(
    $@,
qr/The 'prepare_message' parameter \("invalid"\) to Log::Handler::Output::Gearman::new was a 'scalar', which is not one of the allowed types: coderef/,
    'Invalid prepare_message parameter'
);

{
    my $logger = Log::Handler::Output::Gearman->new(
        servers => ['127.0.0.1:991233123'],
        worker  => 'logger',
    );
    $logger->log('test');
    like( $logger->errstr(), qr/gearman_con_flush:could not connect/, 'Cant connect to Gearman #1' );
}

{
    my $logger  = Log::Handler->new();
    my $gearman = Log::Handler::Output::Gearman->new(
        servers => ['127.0.0.1:991233123'],
        worker  => 'logger',
    );
    my %handler_options = (
        maxlevel       => 'warning',
        minlevel       => 'critical',
        timeformat     => '%Y-%m-%d %H:%M:%S',
        message_layout => '%T [%L] [%P] %m (%X)',
        die_on_errors  => 0,
    );
    $logger->add( $gearman => \%handler_options );
    my $error = '';
    unless ($logger->critical('test123')) {
        $error = $logger->errstr();
    }
    like( $logger->errstr(), qr/gearman_con_flush:could not connect/, 'Cant connect to Gearman #2' );
    
    my $dying_logger = Log::Handler->new();
    $handler_options{die_on_errors} = 1;
    $dying_logger->add($gearman => \%handler_options);
    eval {
        $dying_logger->critical('test123');
    };
    like( $@, qr/Log::Handler::Output: gearman_con_flush:could not connect/, 'Cant connec to Gearman #3 (die)');
}

