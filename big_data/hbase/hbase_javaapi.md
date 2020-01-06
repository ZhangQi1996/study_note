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
        // 过滤器进行OR操作
        // 过滤操作见http://hbase.apache.org/book.html#client.filter
        FilterList list = new FilterList(FilterList.Operator.MUST_PASS_ONE);
        SingleColumnValueFilter filter1 = new SingleColumnValueFilter(
          cf,
          column,
          CompareOperator.EQUAL,
          Bytes.toBytes("my value")
          );
        list.add(filter1);
        SingleColumnValueFilter filter2 = new SingleColumnValueFilter(
          cf,
          column,
          CompareOperator.EQUAL,
          Bytes.toBytes("my other value")
          );
        list.add(filter2);
        scan.setFilter(list);
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
#### Filter
1. FilterList
    * FilterList list = new FilterList(FilterList.Operator.MUST_PASS_ONE); // 保证只要通过其中给一个过滤即可
    * FilterList list = new FilterList(FilterList.Operator.MUST_PASS_ALL); // 要求全部满足要求
    * FilterListWithOR // 实测目似不等价于new FilterList(FilterList.Operator.MUST_PASS_ONE);
    * FilterListWithAND // 实测目似不等价于new FilterList(FilterList.Operator.MUST_PASS_ALL);
2. 列值查询
    * 根据列值筛选符合条件的cell或者row
    1. SingleColumnValueFilter类
        * 根据列族，列和与值得相关操作来获得**整个ROW(包含多列)**
        * 相关值操作: CompareOperaor.EQUAL CompareOperaor.NOT_EQUAL CompareOperaor.GREATER
        ```
        SingleColumnValueFilter filter = new SingleColumnValueFilter(
          cf,
          column,
          CompareOperaor.EQUAL,
          Bytes.toBytes("my value") // 这里可以使用列值比较器
          );
        scan.setFilter(filter);
        ```
    2. ColumnValueFilter类
        * 根据列族，列和与值得相关操作来获得**满足条件的cell**
        ```
        ColumnValueFilter filter = new ColumnValueFilter(
          cf,
          column,
          CompareOperaor.EQUAL,
          Bytes.toBytes("my value") // 这里可以使用列值比较器
          );
        scan.setFilter(filter);
        ```
    3. ValueFilter类
        * 当做简单的cf:qualifier:val的查询时候使用这种方式会更高的性能
        ```
        Scan scan = new Scan();
        scan.addColumn(Bytes.toBytes("family"), Bytes.toBytes("qualifier")); // 先筛选出特定列
        ValueFilter vf = new ValueFilter(CompareOperator.EQUAL, // 再在特定列中做筛选
          new BinaryComparator(Bytes.toBytes("value")));
        scan.setFilter(vf);
        ```
3. 比较器
    * 用于在做筛选的时候比较部分
    1. RegexStringComparator类
        * 支持java的正则表达式判断val是否符合条件
        ```
        RegexStringComparator comp = new RegexStringComparator("my.");   // any value that starts with 'my'
        SingleColumnValueFilter filter = new SingleColumnValueFilter(
          cf,
          column,
          CompareOperaor.EQUAL,
          comp
          );
        scan.setFilter(filter);
        ```
    2. SubstringComparator类
        * 在列值比较中用于判断val中是否包含指定的substring，其中对substring是大小写不敏感的
        * Only EQUAL or NOT_EQUAL tests are valid with this comparator.
        ```
        SubstringComparator comp = new SubstringComparator("y val");   // looking for 'my value'
        SingleColumnValueFilter filter = new SingleColumnValueFilter(
          cf,
          column,
          CompareOperaor.EQUAL,
          comp
          );
        scan.setFilter(filter);
        ```
    3. BinaryPrefixComparator类
        * 构造函数: BinaryPrefixComparator(byte[])
        * value与目标byte数组的prefix部分进行比较
    4. BinaryComparator类
4. KeyVal 中的元数据筛选
    1. 若列族名未知可通过FamilyFilter做筛选
    2. 通过QualifierFilter做筛选 
    3. ColumnPrefixFilter就是列名前缀的筛选
        ```
        Table t = ...;
        byte[] row = ...;
        byte[] family = ...;
        byte[] prefix = Bytes.toBytes("abc");
        Scan scan = new Scan(row, row); // (optional) limit to one row
        scan.addFamily(family); // (optional) limit to one family
        Filter f = new ColumnPrefixFilter(prefix);
        scan.setFilter(f);
        scan.setBatch(10); // set this if there could be many columns returned
        ResultScanner rs = t.getScanner(scan);
        for (Result r = rs.next(); r != null; r = rs.next()) {
          for (Cell cell : result.listCells()) {
            // each cell represents a column
          }
        }
        rs.close();
        ```
    4. MultipleColumnPrefixFilter帅选符合多个条件的列名
        ```
        Table t = ...;
        byte[] row = ...;
        byte[] family = ...;
        byte[][] prefixes = new byte[][] {Bytes.toBytes("abc"), Bytes.toBytes("xyz")};
        Scan scan = new Scan(row, row); // (optional) limit to one row
        scan.addFamily(family); // (optional) limit to one family
        Filter f = new MultipleColumnPrefixFilter(prefixes);
        scan.setFilter(f);
        scan.setBatch(10); // set this if there could be many columns returned
        ResultScanner rs = t.getScanner(scan);
        for (Result r = rs.next(); r != null; r = rs.next()) {
          for (Cell cell : result.listCells()) {
            // each cell represents a column
          }
        }
        rs.close();
        ```
    5 RowFilter(CompareOperator op, ByteArrayComparable rowComparator)用于row-key的筛选
        * CompareOperator操作标志EQUAL，NOT_EQUAL, etc.
        * ByteArrayComparable像是BinaryPrefixComparator类
    6 PrefixFilter(byte[] prefix)用于筛选出由相同prefix的row-key
        * 与RowFilter(CompareOperator.EQUAL, new BinaryPrefixComparator(prefix))等价
    7 FirstKeyOnlyFilter用于获取每行的第一个额keyval，常常用于求行数
5. Filter的装饰器
    1. SkipFilter(Filter filter)
        * 凡是filter所通过的cell，其所在的行均保留
        * 注意是行skip
        ```
        Scan scan = new Scan(); // 扫描全部
        // 扫描所有cell选中那些不等于0的cell
        ValueFilter vf = new ValueFilter(CompareOp.NOT_EQUAL, new BinaryComparator(Bytes.toBytes(0));
        scan.setFilter(new SkipFilter());
        ```      
    2. WhileMatchFilter 