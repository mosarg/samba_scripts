use utf8;
package Db::Django::Result::GroupGrouppolicy;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::GroupGrouppolicy

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

=head1 TABLE: C<group_grouppolicy>

=cut

__PACKAGE__->table("group_grouppolicy");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 groupPolicyId

  accessor: 'group_policy_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 groupId_id

  accessor: 'group_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 policyId_id

  accessor: 'policy_id_id'
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
  "groupPolicyId",
  {
    accessor          => "group_policy_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "groupId_id",
  {
    accessor       => "group_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "policyId_id",
  { accessor => "policy_id_id", data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</groupPolicyId>

=back

=cut

__PACKAGE__->set_primary_key("groupPolicyId");

=head1 UNIQUE CONSTRAINTS

=head2 C<groupId_id>

=over 4

=item * L</groupId_id>

=item * L</policyId_id>

=back

=cut

__PACKAGE__->add_unique_constraint("groupId_id", ["groupId_id", "policyId_id"]);

=head1 RELATIONS

=head2 group_id

Type: belongs_to

Related object: L<Db::Django::Result::GroupGroup>

=cut

__PACKAGE__->belongs_to(
  "group_id",
  "Db::Django::Result::GroupGroup",
  { groupId => "groupId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:f65HKsIzNsdNqPNBjLkw8A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
