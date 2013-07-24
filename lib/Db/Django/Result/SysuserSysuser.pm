use utf8;
package Db::Django::Result::SysuserSysuser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::SysuserSysuser

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

=head1 TABLE: C<sysuser_sysuser>

=cut

__PACKAGE__->table("sysuser_sysuser");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 userId

  accessor: 'user_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sidiId

  accessor: 'sidi_id'
  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 surname

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 origin

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 insertOrder

  accessor: 'insert_order'
  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "created",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "modified",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "userId",
  {
    accessor          => "user_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "sidiId",
  { accessor => "sidi_id", data_type => "varchar", is_nullable => 0, size => 20 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "surname",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "origin",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "insertOrder",
  { accessor => "insert_order", data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</userId>

=back

=cut

__PACKAGE__->set_primary_key("userId");

=head1 UNIQUE CONSTRAINTS

=head2 C<sidiId>

=over 4

=item * L</sidiId>

=back

=cut

__PACKAGE__->add_unique_constraint("sidiId", ["sidiId"]);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5uX5at/wagSTKzRSfXME+w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
