use utf8;
package Db::Django::Result::AllocationStudentallocation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AllocationStudentallocation

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

=head1 TABLE: C<allocation_studentallocation>

=cut

__PACKAGE__->table("allocation_studentallocation");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 studentAllocationId_id

  accessor: 'student_allocation_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 classId_id

  accessor: 'class_id_id'
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
  "studentAllocationId_id",
  {
    accessor       => "student_allocation_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "classId_id",
  { accessor => "class_id_id", data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</studentAllocationId_id>

=back

=cut

__PACKAGE__->set_primary_key("studentAllocationId_id");

=head1 RELATIONS

=head2 student_allocation_id

Type: belongs_to

Related object: L<Db::Django::Result::AllocationAllocation>

=cut

__PACKAGE__->belongs_to(
  "student_allocation_id",
  "Db::Django::Result::AllocationAllocation",
  { allocationId => "studentAllocationId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FIAWJqA4Z5eaiwMxA6a/eQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
