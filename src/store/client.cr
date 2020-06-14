require "db"
require "sqlite3"
require "file_utils"

class Store::Client
  @db : DB::Database
  @insert_batch_size : UInt32
  @update_batch_size : UInt32

  def initialize(@path : String, @insert_batch_size = 1000, @update_batch_size = 100)
    @db = DB.open("sqlite3://#{@path}")
  end

  def db
    @db
  end

  def create_schema
    @db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS followers (
        id UNSIGNED BIG INT PRIMARY KEY, 
        name TEXT,
        location TEXT,
        followers_count INTEGER, 
        listed_count INTEGER, 
        statuses_count INTEGER, 
        verified TINYINT, 
        created_at INTEGER,
        message_sent_at INTEGER
      )
    SQL

    @db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS cursors (
        id TEXT PRIMARY KEY, 
        value TEXT
      )
    SQL
  end

  def get_cursor(id : String) : String?
    @db.scalar("SELECT value FROM cursors WHERE id = ?", args: [id]).as(String?)
  rescue DB::NoResultsError
    nil
  end

  def set_cursor(id : String, value : String?)
    values = [id, value]
    @db.exec <<-SQL, args: values
      INSERT INTO cursors (id, value) VALUES (?, ?)
      ON CONFLICT(id) DO UPDATE SET value = excluded.value;
    SQL
  end

  def insert_follower_ids(ids : Array(Int64))
    ids.in_groups_of(@insert_batch_size) do |chunk|
      values = chunk.reject(&.nil?)
      query = values.size.times.map { "(?)" }.join(",")
      db.exec "INSERT INTO followers (id) VALUES #{query}", args: values
    end
  end

  def update_followers_data(users : Array(Twitter::Models::User))
    users.in_groups_of(@update_batch_size) do |chunk|
      @db.transaction do |tx|
        chunk.each do |user|
          next unless user
          values = [user.name, user.location, user.followers_count, user.listed_count, user.statuses_count, user.verified, user.created_at.to_unix, user.id]
          db.exec <<-SQL, args: values
            UPDATE followers SET
              name = ?,
              location = ?,
              followers_count = ?,
              listed_count = ?, 
              statuses_count = ?, 
              verified = ?, 
              created_at = ?
            WHERE id = ?
          SQL
        end
      end
    end
  end

  def mark_as_messaged(ids : Array(Int64))
    ids.in_groups_of(@update_batch_size) do |chunk|
      @db.transaction do |tx|
        chunk.each do |id|
          next unless id
          values = [Time.utc.to_unix, id]
          db.exec <<-SQL, args: values
            UPDATE followers SET message_sent_at = ? WHERE id = ?
          SQL
        end
      end
    end
  end

  def unknown_followers_query
    "SELECT id FROM followers WHERE name IS NULL"
  end

  def unknown_followers
    @db.query unknown_followers_query do |rs|
      rs.each do
        yield rs.read(Int64)
      end
    end
  end

  def unknown_followers_all
    @db.query_all unknown_followers_query, as: Int64
  end

  def unmessaged_followers_query
    "SELECT id, name FROM followers WHERE message_sent_at IS NULL AND name IS NOT NULL"
  end

  def unmessaged_followers
    @db.query unmessaged_followers_query do |rs|
      rs.each do
        yield rs.read(Int64), rs.read(String)
      end
    end
  end

  def unmessaged_followers_all
    @db.query_all unmessaged_followers_query, as: {Int64, String}
  end

  def close
    @db.close
  end

  def terminate!
    FileUtils.rm @path
  end
end
