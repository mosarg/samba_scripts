use utf8;
package Db::Django::Result::SchoolClass;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::SchoolClass

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

=head1 TABLE: C<school_class>

=cut

__PACKAGE__->table("school_class");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 classId

  accessor: 'class_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 ou

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 capacity

  data_type: 'integer'
  extra: {unsigned => 1}
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
  "classId",
  {
    accessor          => "class_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "ou",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "capacity",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
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

=item * L</classId>

=back

=cut

__PACKAGE__->set_primary_key("classId");

=head1 UNIQUE CONSTRAINTS

=head2 C<name>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name"]);

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yGgApBtjlKznfe0uHe3w7A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
