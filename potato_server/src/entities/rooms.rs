use sea_orm::entity::prelude::*;

#[derive(Clone, Debug, PartialEq, DeriveEntityModel)]
#[sea_orm(table_name = "rooms")]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = false)]
    pub id: String,
    pub expires_at: DateTimeUtc,
}

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {
    #[sea_orm(has_many = "super::chunks::Entity")]
    Chunks,
}

impl Related<super::chunks::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::Chunks.def()
    }
}

impl ActiveModelBehavior for ActiveModel {}
