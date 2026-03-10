class Table {
  final int? tableId;
  final String tableName;
  final String status; // 'Empty', 'Occupied'

  Table({
    this.tableId,
    required this.tableName,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'TableID': tableId,
      'TableName': tableName,
      'Status': status,
    };
  }

  factory Table.fromMap(Map<String, dynamic> map) {
    return Table(
      tableId: map['TableID'] as int?,
      tableName: map['TableName'] as String,
      status: map['Status'] as String,
    );
  }
}