use inc::Module::Install;
name 'Code-AnyRunner';
all_from 'lib/Code/AnyRunner.pm';

requires 'File::Temp';
requires 'IPC::Run';
requires 'Unix::Getrusage';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requires 'Test::Class';
auto_set_repository;
auto_include;
WriteAll;
