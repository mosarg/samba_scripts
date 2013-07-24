use utf8;
package Db::Django::Result::DjangoAdminLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::DjangoAdminLog

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

=head1 TABLE: C<django_admin_log>

=cut

__PACKAGE__->table("django_admin_log");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 action_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 content_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 object_id

  data_type: 'longtext'
  is_nullable: 1

=head2 object_repr

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 action_flag

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 change_message

  data_type: 'longtext'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "action_time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "content_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "object_id",
  { data_type => "longtext", is_nullable => 1 },
  "object_repr",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "action_flag",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "change_message",
  { data_type => "longtext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 content_type

Type: belongs_to

Related object: L<Db::Django::Result::DjangoContentType>

=cut

__PACKAGE__->belongs_to(
  "content_type",
  "Db::Django::Result::DjangoContentType",
  { id => "content_type_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:U3HeNOcp3NP3MUcrU//6dA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
