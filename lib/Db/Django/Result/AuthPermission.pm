use utf8;
package Db::Django::Result::AuthPermission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AuthPermission

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

=head1 TABLE: C<auth_permission>

=cut

__PACKAGE__->table("auth_permission");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 content_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 codename

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "content_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "codename",
  { data_type => "varchar", is_nullable => 0, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<content_type_id>

=over 4

=item * L</content_type_id>

=item * L</codename>

=back

=cut

__PACKAGE__->add_unique_constraint("content_type_id", ["content_type_id", "codename"]);

=head1 RELATIONS

=head2 auth_group_permissions

Type: has_many

Related object: L<Db::Django::Result::AuthGroupPermission>

=cut

__PACKAGE__->has_many(
  "auth_group_permissions",
  "Db::Django::Result::AuthGroupPermission",
  { "foreign.permission_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 auth_user_user_permissions

Type: has_many

Related object: L<Db::Django::Result::AuthUserUserPermission>

=cut

__PACKAGE__->has_many(
  "auth_user_user_permissions",
  "Db::Django::Result::AuthUserUserPermission",
  { "foreign.permission_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 content_type

Type: belongs_to

Related object: L<Db::Django::Result::DjangoContentType>

=cut

__PACKAGE__->belongs_to(
  "content_type",
  "Db::Django::Result::DjangoContentType",
  { id => "content_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bKuv842lbfcN0zHdMzAncg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
