use utf8;
package Db::Django::Result::SouthMigrationhistory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::SouthMigrationhistory

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

=head1 TABLE: C<south_migrationhistory>

=cut

__PACKAGE__->table("south_migrationhistory");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 app_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 migration

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 applied

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "app_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "migration",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "applied",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:u3Pd2z//Sk6SEkluvVtOBQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
