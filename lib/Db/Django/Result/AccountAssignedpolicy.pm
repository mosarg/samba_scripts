use utf8;
package Db::Django::Result::AccountAssignedpolicy;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AccountAssignedpolicy

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

=head1 TABLE: C<account_assignedpolicy>

=cut

__PACKAGE__->table("account_assignedpolicy");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 assignedPolicyId

  accessor: 'assigned_policy_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 accountId_id

  accessor: 'account_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 policyId_id

  accessor: 'policy_id_id'
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
  "assignedPolicyId",
  {
    accessor          => "assigned_policy_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "accountId_id",
  {
    accessor       => "account_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "policyId_id",
  {
    accessor       => "policy_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</assignedPolicyId>

=back

=cut

__PACKAGE__->set_primary_key("assignedPolicyId");

=head1 UNIQUE CONSTRAINTS

=head2 C<accountId_id>

=over 4

=item * L</accountId_id>

=item * L</policyId_id>

=back

=cut

__PACKAGE__->add_unique_constraint("accountId_id", ["accountId_id", "policyId_id"]);

=head1 RELATIONS

=head2 account_id

Type: belongs_to

Related object: L<Db::Django::Result::AccountAccount>

=cut

__PACKAGE__->belongs_to(
  "account_id",
  "Db::Django::Result::AccountAccount",
  { accountId => "accountId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 policy_id

Type: belongs_to

Related object: L<Db::Django::Result::AccountPolicy>

=cut

__PACKAGE__->belongs_to(
  "policy_id",
  "Db::Django::Result::AccountPolicy",
  { policyId => "policyId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-28 23:39:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:T6Ajx9tpFAjYh0Gc8wcdag


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
