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
  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

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

=head2 syncModel

  accessor: 'sync_model'
  data_type: 'varchar'
  is_nullable: 0
  size: 30

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
  {
    accessor    => "sidi_id",
    data_type   => "integer",
    extra       => { unsigned => 1 },
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "surname",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "origin",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "insertOrder",
  { accessor => "insert_order", data_type => "integer", is_nullable => 0 },
  "syncModel",
  {
    accessor => "sync_model",
    data_type => "varchar",
    is_nullable => 0,
    size => 30,
  },
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

=head1 RELATIONS

=head2 account_accounts

Type: has_many

Related object: L<Db::Django::Result::AccountAccount>

=cut

__PACKAGE__->has_many(
  "account_accounts",
  "Db::Django::Result::AccountAccount",
  { "foreign.userId_id" => "self.userId" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 allocation_allocations

Type: has_many

Related object: L<Db::Django::Result::AllocationAllocation>

=cut

__PACKAGE__->has_many(
  "allocation_allocations",
  "Db::Django::Result::AllocationAllocation",
  { "foreign.userId_id" => "self.userId" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-21 15:32:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uKoRUIFIOPFz4o5k1FpYHA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
