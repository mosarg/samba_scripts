use utf8;
package Db::Django::Result::AccountAccount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AccountAccount

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

=head1 TABLE: C<account_account>

=cut

__PACKAGE__->table("account_account");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 accountId

  accessor: 'account_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 active

  data_type: 'tinyint'
  is_nullable: 0

=head2 backendUidNumber

  accessor: 'backend_uid_number'
  data_type: 'integer'
  is_nullable: 0

=head2 userId_id

  accessor: 'user_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 backendId_id

  accessor: 'backend_id_id'
  data_type: 'integer'
  is_foreign_key: 1
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
  "accountId",
  {
    accessor          => "account_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "active",
  { data_type => "tinyint", is_nullable => 0 },
  "backendUidNumber",
  {
    accessor    => "backend_uid_number",
    data_type   => "integer",
    is_nullable => 0,
  },
  "userId_id",
  {
    accessor       => "user_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "backendId_id",
  {
    accessor       => "backend_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</accountId>

=back

=cut

__PACKAGE__->set_primary_key("accountId");

=head1 UNIQUE CONSTRAINTS

=head2 C<userId_id>

=over 4

=item * L</userId_id>

=item * L</backendId_id>

=back

=cut

__PACKAGE__->add_unique_constraint("userId_id", ["userId_id", "backendId_id"]);

=head1 RELATIONS

=head2 account_assignedpolicies

Type: has_many

Related object: L<Db::Django::Result::AccountAssignedpolicy>

=cut

__PACKAGE__->has_many(
  "account_assignedpolicies",
  "Db::Django::Result::AccountAssignedpolicy",
  { "foreign.accountId_id" => "self.accountId" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 backend_id

Type: belongs_to

Related object: L<Db::Django::Result::BackendBackend>

=cut

__PACKAGE__->belongs_to(
  "backend_id",
  "Db::Django::Result::BackendBackend",
  { backendId => "backendId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 user_id

Type: belongs_to

Related object: L<Db::Django::Result::SysuserSysuser>

=cut

__PACKAGE__->belongs_to(
  "user_id",
  "Db::Django::Result::SysuserSysuser",
  { userId => "userId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 21:51:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FxH+YOvEKiEq3DVwgJtfQg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
