#### 创建/修改/删除表
```
public class Example {

  private static final String TABLE_NAME = "MY_TABLE_NAME_TOO";
  private static final String CF_DEFAULT = "DEFAULT_COLUMN_FAMILY";

  public static void createOrOverwrite(Admin admin, HTableDescriptor table) throws IOException {
    if (admin.tableExists(table.getTableName())) {
      admin.disableTable(table.getTableName());
      admin.deleteTable(table.getTableName());
    }
    admin.createTable(table);
  }

  public static void createSchemaTables(Configuration config) throws IOException {
    try (Connection connection = ConnectionFactory.createConnection(config);
         Admin admin = connection.getAdmin()) {

      HTableDescriptor table = new HTableDescriptor(TableName.valueOf(TABLE_NAME));
      table.addFamily(new HColumnDescriptor(CF_DEFAULT).setCompressionType(Algorithm.NONE));

      System.out.print("Creating table. ");
      createOrOverwrite(admin, table);
      System.out.println(" Done.");
    }
  }

  public static void modifySchema (Configuration config) throws IOException {
    try (Connection connection = ConnectionFactory.createConnection(config);
         Admin admin = connection.getAdmin()) {

      TableName tableName = TableName.valueOf(TABLE_NAME);
      if (!admin.tableExists(tableName)) {
        System.out.println("Table does not exist.");
        System.exit(-1);
      }

      HTableDescriptor table = admin.getTableDescriptor(tableName);

      // Update existing table
      HColumnDescriptor newColumn = new HColumnDescriptor("NEWCF");
      newColumn.setCompactionCompressionType(Algorithm.GZ);
      newColumn.setMaxVersions(HConstants.ALL_VERSIONS);
      admin.addColumn(tableName, newColumn);

      // Update existing column family
      HColumnDescriptor existingColumn = new HColumnDescriptor(CF_DEFAULT);
      existingColumn.setCompactionCompressionType(Algorithm.GZ);
      existingColumn.setMaxVersions(HConstants.ALL_VERSIONS);
      table.modifyFamily(existingColumn);
      admin.modifyTable(tableName, table);

      // Disable an existing table
      admin.disableTable(tableName);

      // Delete an existing column family
      admin.deleteColumn(tableName, CF_DEFAULT.getBytes("UTF-8"));

      // Delete a table (Need to be disabled first)
      admin.deleteTable(tableName);
    }
  }

  public static void main(String... args) throws IOException {
    Configuration config = HBaseConfiguration.create();

    //Add any necessary configuration files (hbase-site.xml, core-site.xml)
    config.addResource(new Path(System.getenv("HBASE_CONF_DIR"), "hbase-site.xml"));
    config.addResource(new Path(System.getenv("HADOOP_CONF_DIR"), "core-site.xml"));
    createSchemaTables(config);
    modifySchema(config);
  }
}
```
#### 增删查
```
public class Demo {

    Admin admin;
    Connection conn;
    Table table;

    @Before
    public void connect() throws IOException {
        Configuration conf = new Configuration();
        conf.set("hbase.zookeeper.quorum", "qc");
        conn = ConnectionFactory.createConnection(conf);
        table = conn.getTable(TableName.valueOf("t"));
    }

    @Test
    public void put() throws IOException {
        String rowKey = "2";
        Put put = new Put(rowKey.getBytes());
        put.addColumn("f".getBytes(), "name".getBytes(), "phoebe".getBytes());
        put.addColumn("f".getBytes(), "age".getBytes(), "22".getBytes());
        table.put(put);
    }

    @Test
    public void get() throws IOException {
        table = conn.getTable(TableName.valueOf("t"));
        Get get = new Get("2".getBytes());
        // 为了解决查询过多列
        get.addColumn("f".getBytes(), "name".getBytes());
        Result rst = table.get(get);
        Cell c = rst.getColumnLatestCell("f".getBytes(), "name".getBytes());
        System.out.println(Bytes.toString(CellUtil.cloneRow(c)));
        System.out.println(Bytes.toString(CellUtil.cloneValue(c)));
    }

    @Test
    public void scan() throws IOException {
        Scan scan = new Scan();
        ResultScanner scanner = table.getScanner(scan);
        for (Result rst: scanner) {
            Cell c = rst.getColumnLatestCell("f".getBytes(), "name".getBytes());
            System.out.println(Bytes.toString(CellUtil.cloneRow(c)));
            System.out.println(Bytes.toString(CellUtil.cloneValue(c)));
        }
    }

    @Test
    public void delete() throws IOException {
        Delete del = new Delete("2".getBytes());
        // 删除cell中的最新版本（最新时间戳的）的数据
        del.addColumn("f".getBytes(), "col".getBytes());
        // 删除cell中特定版本的（时间戳）的数据
        del.addColumn("f".getBytes(), "col".getBytes(), 123L);
        // 删除这个f:col下cell中所有版本的数据
        del.addColumns("f".getBytes(), "col".getBytes());
        // 删除这个f:col下cell中小于等于特定时间戳的所有数据
        del.addColumns("f".getBytes(), "col".getBytes(), 123L);
        table.delete(del);
    }

    @After
    public void close() {
        IOUtils.closeStream(admin);
        IOUtils.closeStream(conn);
    }
}
```