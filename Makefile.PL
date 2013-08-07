use inc::Module::Install;
name 'Code-AnyRunner';
all_from 'lib/Code/AnyRunner.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
