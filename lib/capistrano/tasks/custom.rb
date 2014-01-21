desc "send database.yml"
task :send_database_yml do
  on roles(:all) do
    template("database.production.yml", "#{fetch :dir_conf}/database.yml")
  end
end
end