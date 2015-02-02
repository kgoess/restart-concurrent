#!/usr/bin/env perl6


my $promise1 = sometask1();
my $promise2 = sometask2();
my $promise3 = sometask3();

show_results([$promise1, $promise2, $promise3]);


sub sometask1() {
     return run_task('/bin/sleep 2 && /bin/echo', ['task1 ok']);
}
sub sometask2() {
     return run_task('/bin/sleep', [2]);
}
sub sometask3() {
     return run_task('/bin/ls', ['lksdfasdfasdf']);
}

sub run_task($prog, @args){

    my $p = Promise.start({

        my $proc = Proc::Async.new( $prog, @args);

        my %result;

        # subscribe to new output from out and err handles:
        $proc.stdout.tap(-> $v { %result{"stdout"} = $v });
        $proc.stderr.tap(-> $v { %result{"stderr"} = $v });

        my $proc_promise = $proc.start;

        # wait for the external program to terminate
        await $proc_promise;

        #$v.keep( %result );
        return %result;
    });

    return $p;
}

sub show_results(@promises) {
    say "in show_results";
    my %p1_result = @promises[0].result;
    my %p2_result = @promises[1].result;
    my %p3_result = @promises[2].result;

    say "p1 %p1_result.perl()";
    say "p2 %p2_result.perl()";
    say "p3 %p3_result.perl()";
}

__END__

    This throws different exceptions, sometimes hangs
    
    It is based on the code at http://doc.perl6.org/type/Proc%3A%3AAsync
    
    $ ./restart.pl
    in show_results
    Unhandled exception in code scheduled on thread 4530032640
    ===SORRY!===
    P6opaque: no such attribute '$!tappers_lock'
    
    $ ./restart.pl
    in show_results
    ===SORRY!===
    P6opaque: no such attribute '$!tappers_lock'
    
    $ ./restart.pl
    in show_results
    ^C


