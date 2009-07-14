use strict;
use warnings;
use Log::Handler::Output::Gearman;
use Test::More tests => 3;

eval { my $logger = Log::Handler::Output::Gearman->new(); };

like(
    $@,
    qr/Mandatory parameters 'worker', 'host' missing in call to Log::Handler::Output::Gearman::new/,
    'Mandatory parameters missing'
);

eval { my $logger = Log::Handler::Output::Gearman->new( method => 'invalid' ); };

like(
    $@,
    qr/The 'method' parameter \("invalid"\) to Log::Handler::Output::Gearman::new did not pass regex check/,
    'Invalid Gearman::XS::Client method'
);

eval { my $logger = Log::Handler::Output::Gearman->new( port => 'invalid' ); };

like(
    $@,
    qr/The 'port' parameter \("invalid"\) to Log::Handler::Output::Gearman::new did not pass regex check/,
    'Invalid port parameter'
);
