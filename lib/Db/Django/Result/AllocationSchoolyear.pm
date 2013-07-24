use utf8;
package Db::Django::Result::AllocationSchoolyear;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AllocationSchoolyear

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

=head1 TABLE: C<allocation_schoolyear>

=cut

__PACKAGE__->table("allocation_schoolyear");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 schoolYearId

  accessor: 'school_year_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 year

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 1000

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
  "schoolYearId",
  {
    accessor          => "school_year_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "year",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 1000 },
  "active",
  { data_type => "tinyint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</schoolYearId>

=back

=cut

__PACKAGE__->set_primary_key("schoolYearId");

=head1 UNIQUE CONSTRAINTS

=head2 C<year>

=over 4

=item * L</year>

=back

=cut

__PACKAGE__->add_unique_constraint("year", ["year"]);

=head1 RELATIONS

=head2 allocation_allocations

Type: has_many

Related object: L<Db::Django::Result::AllocationAllocation>

=cut

__PACKAGE__->has_many(
  "allocation_allocations",
  "Db::Django::Result::AllocationAllocation",
  { "foreign.yearId_id" => "self.schoolYearId" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IUGd90LuhJfaCGZehAs4Ww


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
