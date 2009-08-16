package POEx::Role::TCPClient;
our $VERSION = '0.092280';


#ABSTRACT: A Moose Role that provides TCPClient behavior

use MooseX::Declare;

role POEx::Role::TCPClient 
{
    with 'POEx::Role::SessionInstantiation';
    use MooseX::AttributeHelpers;
    use POEx::Types(':all');
    use MooseX::Types::Moose(':all');
    use POE::Wheel::ReadWrite;
    use POE::Wheel::SocketFactory;
    use POE::Filter::Line;
    
    use aliased 'POEx::Role::Event';


    requires 'handle_inbound_data';


    has socket_factories =>
    (
        metaclass   => 'MooseX::AttributeHelpers::Collection::Hash',
        isa         => HashRef[Object],
        lazy        => 1,
        default     => sub { {} },
        clearer     => 'clear_socket_factories',
        provides    =>
        {
            get     => 'get_socket_factory',
            set     => 'set_socket_factory',
            delete  => 'delete_socket_factory',
            count   => 'has_socket_factories',
            exists  => 'has_socket_factory',
        }
    );


    has wheels =>
    (
        metaclass   => 'MooseX::AttributeHelpers::Collection::Hash',
        isa         => HashRef[Object],
        lazy        => 1,
        default     => sub { {} },
        clearer     => 'clear_wheels',
        provides    =>
        {
            get     => 'get_wheel',
            set     => 'set_wheel',
            delete  => 'delete_wheel',
            count   => 'has_wheels',
        }
    );


    has last_wheel =>
    (
        is          => 'rw',
        isa         => WheelID,
    );


    has filter =>
    (
        is          => 'rw',
        isa         => Filter,
        default     => sub { POE::Filter::Line->new() }
    );


    has connection_tags =>
    (
        metaclass   => 'MooseX::AttributeHelpers::Collection::Hash',
        isa         => HashRef[Ref],
        lazy        => 1,
        default     => sub { {} },
        clearer     => 'clear_connection_tags',
        provides    =>
        {
            get     => 'get_connection_tag',
            set     => 'set_connection_tag',
            delete  => 'delete_connection_tag',
            count   => 'has_connection_tags',
            exists  => 'has_connection_tag',
        }

    );


    method connect(Str :$remote_address, Int :$remote_port, Ref :$tag?) is Event
    {
        my $sfactory = POE::Wheel::SocketFactory->new
        (
            RemoteAddress       => $remote_address,
            RemotePort          => $remote_port,
            SuccessEvent        => 'handle_on_connect',
            FailureEvent        => 'handle_connect_error',
            Reuse               => 1,
        );

        $self->set_socket_factory($sfactory->ID, $sfactory);

        $self->set_connection_tag($sfactory->ID, $tag) if defined($tag);
    }


    method handle_on_connect (GlobRef $socket, Str $address, Int $port, WheelID $id) is Event
    {
        my $wheel = POE::Wheel::ReadWrite->new
        (
            Handle      => $socket,
            Filter      => $self->filter->clone(),
            InputEvent  => 'handle_inbound_data',
            ErrorEvent  => 'handle_socket_error',
        );
        
        $self->set_wheel($wheel->ID, $wheel);
        $self->last_wheel($wheel->ID);
        $self->delete_socket_factory($id);
    }


    method handle_connect_error(Str $action, Int $code, Str $message, WheelID $id) is Event
    {
        warn "Received connect error: Action $action, Code $code, Message $message from $id"
            if $self->options->{'debug'};
    }


    method handle_socket_error(Str $action, Int $code, Str $message, WheelID $id) is Event
    {
        warn "Received socket error: Action $action, Code $code, Message $message from $id"
            if $self->options->{'debug'};
    }


    method shutdown() is Event
    {
        $self->clear_socket_factories;
        $self->clear_wheels;
        $self->clear_alias;
        $self->poe->kernel->alias_remove($_) for $self->poe->kernel->alias_list();
    }
}

1;



=pod

=head1 NAME

POEx::Role::TCPClient - A Moose Role that provides TCPClient behavior

=head1 VERSION

version 0.092280

=head1 REQUIRES

=head2 METHODS

=head3 handle_inbound_data($data, WheelID $id) is Event

This required method will be passed the data received, and from which wheel 
it came. 



=head1 DESCRIPTION

POEx::Role::TCPClient bundles up the lower level SocketFactory/ReadWrite
combination of wheels into a simple Moose::Role. It builds upon other POEx
modules such as POEx::Role::SessionInstantiation and POEx::Types. 

The events for SocketFactory and for each ReadWrite instantiated are
methods that can be advised in any way deemed fit. Advising these methods
is actually encouraged and can simplify code for the consumer. 

The only method that must be provided by the consuming class is 
handle_inbound_data.

The connect event must be invoked to initiate a connection.

=head1 ATTRIBUTES

=head2 socket_factories metaclass: Collection::Hash, isa: HashRef[Object]

The POE::Wheel::SocketFactory objects created in connect are stored here and 
managed via the following provides:

    provides    =>
    {
        get     => 'get_socket_factory',
        set     => 'set_socket_factory',
        delete  => 'delete_socket_factory',
        count   => 'has_socket_factories',
        exists  => 'has_socket_factory',
    }



=head2 wheels metaclass: Collection::Hash, isa: HashRef, clearer: clear_wheels

When connections are finished, a POE::Wheel::ReadWrite object is created and 
stored in this attribute, keyed by WheelID. Wheels may be accessed via the
following provided methods. See MooseX::AttributeHelpers::Collection::Hash
for more details.

    provides    =>
    {
        get     => 'get_wheel',
        set     => 'set_wheel',
        delete  => 'delete_wheel',
        count   => 'has_wheels',
    }



=head2 last_wheel is: rw, isa: WheelID

This holds the last ID created from the handle_on_connect method. Handy if the
protocol requires client initiation.



=head2 filter is: rw, isa: Filter

This stores the filter that is used when constructing wheels. It will be cloned
for each connection completed.



=head2 connection_tags metaclass: Collection::Hash, is: ro, isa: HashRef[Ref]

This stores any arbitrary user data passed to connect keyed by the socket
factory ID. Handy to match up multiple connects for composers.

    provides    =>
    {
        get     => 'get_connection_tag',
        set     => 'set_connection_tag',
        delete  => 'delete_connection_tag',
        count   => 'has_connection_tags',
        exists  => 'has_connection_tag',
    }



=head2 connect(Str :$remote_address, Int :$remote_port, Ref :$tag?) is Event

connect is used to initiate a connection to a remote source. It accepts two 
named arguments that both required, remote_address and remote_port. They are 
passed directly to SocketFactory. If tag is provided, it will be stored in 
connection_tags and keyed by the socket factory's ID.



=head2 handle_on_connect(GlobRef $socket, Str $address, Int $port, WheelID $id) is Event

handle_on_connect is the SuccessEvent of the SocketFactory instantiated in _start. 



=head2 handle_connect_error(Str $action, Int $code, Str $message, WheelID $id) is Event

handle_connect_error is the FailureEvent of the SocketFactory



=head2 handle_socket_error(Str $action, Int $code, Str $message, WheelID $id) is Event

handle_socket_error is the ErrorEvent of each POE::Wheel::ReadWrite instantiated.



=head2 shutdown() is Event

shutdown unequivically terminates the TCPClient by clearing all wheels and 
aliases, forcing POE to garbage collect the session.



=head1 AUTHOR

  Nicholas Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2009 by Nicholas Perez.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut 



__END__
