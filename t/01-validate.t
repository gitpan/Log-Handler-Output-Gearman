use strict;
use warnings;
use Log::Handler::Output::Gearman;
use Test::More tests => 5;

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

eval {
    my $logger = Log::Handler::Output::Gearman->new(
        servers         => ['127.0.0.1:991233123'],
        worker          => 'logger',
    );
	$logger->log('test');
};
like($@, qr/Log::Handler::Output::Gearman::log\(\): gearman_con_flush:could not connect/, 'Cant connect to Gearman error message');
