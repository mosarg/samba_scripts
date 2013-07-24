use utf8;
package Db::Django::Result::SchoolSubject;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::SchoolSubject

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

=head1 TABLE: C<school_subject>

=cut

__PACKAGE__->table("school_subject");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 subjectId

  accessor: 'subject_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 code

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 shortDescription

  accessor: 'short_description'
  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 niceName

  accessor: 'nice_name'
  data_type: 'varchar'
  is_nullable: 0
  size: 50

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
  "subjectId",
  {
    accessor          => "subject_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "code",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "shortDescription",
  {
    accessor => "short_description",
    data_type => "varchar",
    is_nullable => 0,
    size => 100,
  },
  "niceName",
  {
    accessor => "nice_name",
    data_type => "varchar",
    is_nullable => 0,
    size => 50,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</subjectId>

=back

=cut

__PACKAGE__->set_primary_key("subjectId");

=head1 UNIQUE CONSTRAINTS

=head2 C<code>

=over 4

=item * L</code>

=back

=cut

__PACKAGE__->add_unique_constraint("code", ["code"]);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UpVg7QqQ/jrJ6NPbiCRAzQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
