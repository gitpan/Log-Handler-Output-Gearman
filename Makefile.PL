use inc::Module::Install;

if ( -e 'MANIFEST.SKIP' ) {
    system('pod2text lib/Log/Handler/Output/Gearman.pm > README');
}

perl_version '5.006001';

name 'Log-Handler-Output-Gearman';
all_from 'lib/Log/Handler/Output/Gearman.pm';

requires(
    'Log::Handler' => '0.56',
    'Gearman::XS'  => '0.3',
);

test_requires 'Test::More';

auto_install;
WriteAll;
