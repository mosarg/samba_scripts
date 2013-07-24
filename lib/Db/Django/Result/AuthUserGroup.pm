use utf8;
package Db::Django::Result::AuthUserGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AuthUserGroup

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

=head1 TABLE: C<auth_user_groups>

=cut

__PACKAGE__->table("auth_user_groups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<user_id>

=over 4

=item * L</user_id>

=item * L</group_id>

=back

=cut

__PACKAGE__->add_unique_constraint("user_id", ["user_id", "group_id"]);

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

=head2 user

Type: belongs_to

Related object: L<Db::Django::Result::AuthUser>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Db::Django::Result::AuthUser",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SOE1N1g2CGlU/UxqM0XtbQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
