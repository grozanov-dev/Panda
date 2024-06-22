#!/usr/bin/perl

use lib './lib';
use utf8;
use feature qw/say state/;
use strict;
use warnings;
use Data::Dumper;

use MyApp::Accessor;

{

    my $app = MyApp::Accessor->new( 'param_1', 'param_2' );

    $app->param_1( 'value 1' );

    say 'MyApp::Accessor::param_1 = ', $app->param_1;

    $app->param_2( 'value 2' );

    say 'MyApp::Accessor::param_2 = ', $app->param_2;

}

1;

=pod

Напишите на Perl примитивный базовый класс MyApp::Accessor для
использования в качестве базового класса для генерации аксессоров
(методов которые сохраняют и отдают свойство объекта). Аксессоры
должны работать настолько быстро, насколько это возможно в принципе.
Какими технологиями/модулями, по вашему, лучше всего пользоваться в
реальной разработке для создания аксессоров?
P.S. Accessor – это примитивная функция, которая служит для доступа к
свойству объекта извне.
Т.е. $obj->property – возвращает значение, а $obj->property($value) –
устанавливает.