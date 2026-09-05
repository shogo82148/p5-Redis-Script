requires 'perl', '5.024000';
requires 'Digest::SHA';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Redis';
    requires 'Test::RedisServer';
};

