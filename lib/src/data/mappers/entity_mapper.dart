typedef EntityMapper<Entity, Model> = ({
  Entity Function(Model) responseMapper,
  Model Function(Entity)? requestMapper,
});
