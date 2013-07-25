use utf8;
package Db::Django::Result::AllocationTeacherallocation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AllocationTeacherallocation

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

=head1 TABLE: C<allocation_teacherallocation>

=cut

__PACKAGE__->table("allocation_teacherallocation");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 teacherAllocationId

  accessor: 'teacher_allocation_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 allocationId_id

  accessor: 'allocation_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 classId_id

  accessor: 'class_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 subjectId_id

  accessor: 'subject_id_id'
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
  "teacherAllocationId",
  {
    accessor          => "teacher_allocation_id",
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
  "classId_id",
  {
    accessor       => "class_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "subjectId_id",
  {
    accessor       => "subject_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</teacherAllocationId>

=back

=cut

__PACKAGE__->set_primary_key("teacherAllocationId");

=head1 UNIQUE CONSTRAINTS

=head2 C<classId_id>

=over 4

=item * L</classId_id>

=item * L</subjectId_id>

=item * L</teacherAllocationId>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "classId_id",
  ["classId_id", "subjectId_id", "teacherAllocationId"],
);

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

=head2 class_id

Type: belongs_to

Related object: L<Db::Django::Result::SchoolClass>

=cut

__PACKAGE__->belongs_to(
  "class_id",
  "Db::Django::Result::SchoolClass",
  { classId => "classId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 subject_id

Type: belongs_to

Related object: L<Db::Django::Result::SchoolSubject>

=cut

__PACKAGE__->belongs_to(
  "subject_id",
  "Db::Django::Result::SchoolSubject",
  { subjectId => "subjectId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 21:51:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M0kZiRg0iqNXlb2IXpO1JA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
