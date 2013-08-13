use inc::Module::Install;
name 'Code-AnyRunner';
all_from 'lib/Code/AnyRunner.pm';

tests 't/*.t';
author_tests 'xt';

auto_set_repository;
auto_include;

cpanfile;
WriteAll;
