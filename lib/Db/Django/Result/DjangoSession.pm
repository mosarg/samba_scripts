use utf8;
package Db::Django::Result::DjangoSession;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::DjangoSession

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<django_session>

=cut

__PACKAGE__->table("django_session");

=head1 ACCESSORS

=head2 session_key

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 session_data

  data_type: 'longtext'
  is_nullable: 0

=head2 expire_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "session_key",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "session_data",
  { data_type => "longtext", is_nullable => 0 },
  "expire_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</session_key>

=back

=cut

__PACKAGE__->set_primary_key("session_key");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gTyH8dGP5SiN87mWlvXSRA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
