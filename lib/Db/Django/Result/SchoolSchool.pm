use utf8;
package Db::Django::Result::SchoolSchool;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::SchoolSchool

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

=head1 TABLE: C<school_school>

=cut

__PACKAGE__->table("school_school");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 schoolId

  accessor: 'school_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 meccanographic

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 ou

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 active

  data_type: 'tinyint'
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
  "schoolId",
  {
    accessor          => "school_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "meccanographic",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "ou",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "active",
  { data_type => "tinyint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</schoolId>

=back

=cut

__PACKAGE__->set_primary_key("schoolId");

=head1 UNIQUE CONSTRAINTS

=head2 C<meccanographic>

=over 4

=item * L</meccanographic>

=back

=cut

__PACKAGE__->add_unique_constraint("meccanographic", ["meccanographic"]);

=head1 RELATIONS

=head2 school_classes

Type: has_many

Related object: L<Db::Django::Result::SchoolClass>

=cut

__PACKAGE__->has_many(
  "school_classes",
  "Db::Django::Result::SchoolClass",
  { "foreign.schoolId_id" => "self.schoolId" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ye1Nm8qGmp6CjU1z6ZA0Sg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
