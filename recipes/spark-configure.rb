spark_user = node['apache_spark']['user']
spark_group = node['apache_spark']['group']

spark_install_dir = node['apache_spark']['install_dir']
spark_conf_dir = ::File.join(spark_install_dir, 'conf')
local_dirs = node['apache_spark']['standalone']['local_dirs']

template "#{spark_conf_dir}/spark-env.sh" do
  source 'spark-env.sh.erb'
  mode 0644
  owner spark_user
  group spark_group
  variables node['apache_spark']['standalone']
end

template "#{spark_conf_dir}/log4j.properties" do
  source 'spark_log4j.properties.erb'
  mode 0644
  owner spark_user
  group spark_group
  variables node['apache_spark']['standalone']
end

common_extra_classpath_items_str =
  node['apache_spark']['standalone']['common_extra_classpath_items'].join(':')

default_executor_mem_mb = node['apache_spark']['standalone']['default_executor_mem_mb']

template "#{spark_conf_dir}/spark-defaults.conf" do
  source 'spark-defaults.conf.erb'
  mode 0644
  owner spark_user
  group spark_group
  variables options: node['apache_spark']['conf'].to_hash.merge(
    'spark.driver.extraClassPath' => common_extra_classpath_items_str,
    'spark.executor.extraClassPath' => common_extra_classpath_items_str,
    'spark.executor.memory' => "#{default_executor_mem_mb}m",
    'spark.local.dir' => local_dirs.join(',')
  )
end
