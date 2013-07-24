use utf8;
package Db::Django::Result::DjangoContentType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::DjangoContentType

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

=head1 TABLE: C<django_content_type>

=cut

__PACKAGE__->table("django_content_type");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 app_label

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 model

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "app_label",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "model",
  { data_type => "varchar", is_nullable => 0, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<app_label>

=over 4

=item * L</app_label>

=item * L</model>

=back

=cut

__PACKAGE__->add_unique_constraint("app_label", ["app_label", "model"]);

=head1 RELATIONS

=head2 auth_permissions

Type: has_many

Related object: L<Db::Django::Result::AuthPermission>

=cut

__PACKAGE__->has_many(
  "auth_permissions",
  "Db::Django::Result::AuthPermission",
  { "foreign.content_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 django_admin_logs

Type: has_many

Related object: L<Db::Django::Result::DjangoAdminLog>

=cut

__PACKAGE__->has_many(
  "django_admin_logs",
  "Db::Django::Result::DjangoAdminLog",
  { "foreign.content_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 11:37:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MqK/ALOvVRPuywAh3HaJoA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
