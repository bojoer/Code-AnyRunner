requires 'Config::Tiny';
requires 'File::Temp';
requires 'IPC::Run';
requires 'Unix::Getrusage';

test_requires 'Test::More';
test_requires 'Test::Class';

on 'develop' => sub {
    requires 'Module::Install';
    requires 'Module::Install::CPANfile';
    requires 'Module::Install::AuthorTests';
    requires 'Module::Install::Repository';

    requires 'Devel::Cover::Report::Coveralls';
};
