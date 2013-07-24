use utf8;
package Db::Django::Result::AuthGroupPermission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AuthGroupPermission

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

=head1 TABLE: C<auth_group_permissions>

=cut

__PACKAGE__->table("auth_group_permissions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 permission_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "permission_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<group_id>

=over 4

=item * L</group_id>

=item * L</permission_id>

=back

=cut

__PACKAGE__->add_unique_constraint("group_id", ["group_id", "permission_id"]);

=head1 RELATIONS

=head2 group

Type: belongs_to

Related object: L<Db::Django::Result::AuthGroup>

=cut

__PACKAGE__->belongs_to(
  "group",
  "Db::Django::Result::AuthGroup",
  { id => "group_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 permission

Type: belongs_to

Related object: L<Db::Django::Result::AuthPermission>

=cut

__PACKAGE__->belongs_to(
  "permission",
  "Db::Django::Result::AuthPermission",
  { id => "permission_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hP+kIJA9kRE0O62Gi45o8A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
