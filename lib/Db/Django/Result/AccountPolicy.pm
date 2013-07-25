use utf8;
package Db::Django::Result::AccountPolicy;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AccountPolicy

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

=head1 TABLE: C<account_policy>

=cut

__PACKAGE__->table("account_policy");

=head1 ACCESSORS

=head2 policyId

  accessor: 'policy_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 backendId_id

  accessor: 'backend_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "policyId",
  {
    accessor          => "policy_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 300 },
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

=item * L</policyId>

=back

=cut

__PACKAGE__->set_primary_key("policyId");

=head1 UNIQUE CONSTRAINTS

=head2 C<account_policy_name_42b6fb59870e0912_uniq>

=over 4

=item * L</name>

=item * L</backendId_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "account_policy_name_42b6fb59870e0912_uniq",
  ["name", "backendId_id"],
);

=head1 RELATIONS

=head2 account_assignedpolicies

Type: has_many

Related object: L<Db::Django::Result::AccountAssignedpolicy>

=cut

__PACKAGE__->has_many(
  "account_assignedpolicies",
  "Db::Django::Result::AccountAssignedpolicy",
  { "foreign.policyId_id" => "self.policyId" },
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

=head2 configuration_profiles

Type: has_many

Related object: L<Db::Django::Result::ConfigurationProfile>

=cut

__PACKAGE__->has_many(
  "configuration_profiles",
  "Db::Django::Result::ConfigurationProfile",
  { "foreign.defaultPolicy_id" => "self.policyId" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 group_grouppolicies

Type: has_many

Related object: L<Db::Django::Result::GroupGrouppolicy>

=cut

__PACKAGE__->has_many(
  "group_grouppolicies",
  "Db::Django::Result::GroupGrouppolicy",
  { "foreign.policyId_id" => "self.policyId" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-25 21:49:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nqY6kAbn84zxc6iEy0SjfQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
