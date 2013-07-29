use utf8;
package Db::Django::Result::AllocationNondidacticalallocation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AllocationNondidacticalallocation

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

=head1 TABLE: C<allocation_nondidacticalallocation>

=cut

__PACKAGE__->table("allocation_nondidacticalallocation");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 nonDidacticalAllocationId

  accessor: 'non_didactical_allocation_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 allocationId_id

  accessor: 'allocation_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 schoolId_id

  accessor: 'school_id_id'
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
  "nonDidacticalAllocationId",
  {
    accessor          => "non_didactical_allocation_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "allocationId_id",
  {
    accessor       => "allocation_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "schoolId_id",
  {
    accessor       => "school_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</nonDidacticalAllocationId>

=back

=cut

__PACKAGE__->set_primary_key("nonDidacticalAllocationId");

=head1 RELATIONS

=head2 allocation_id

Type: belongs_to

Related object: L<Db::Django::Result::AllocationAllocation>

=cut

__PACKAGE__->belongs_to(
  "allocation_id",
  "Db::Django::Result::AllocationAllocation",
  { allocationId => "allocationId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 school_id

Type: belongs_to

Related object: L<Db::Django::Result::SchoolSchool>

=cut

__PACKAGE__->belongs_to(
  "school_id",
  "Db::Django::Result::SchoolSchool",
  { schoolId => "schoolId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-28 23:39:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ALuZuRRfSdzcFSdLN8Kytg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
