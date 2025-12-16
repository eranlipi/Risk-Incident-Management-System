using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

/// <summary>
/// Data Access Layer - Handles all database operations
/// Uses parameterized queries and stored procedures to prevent SQL injection
/// </summary>
public class DatabaseHelper
{
    private readonly string _connectionString;

    /// <summary>
    /// Constructor - Initializes connection string from Web.config
    /// </summary>
    public DatabaseHelper()
    {
        _connectionString = ConfigurationManager.ConnectionStrings["IncidentDB"].ConnectionString;
    }

    #region Connection Management

    /// <summary>
    /// Creates and returns a new SQL connection
    /// </summary>
    private SqlConnection GetConnection()
    {
        return new SqlConnection(_connectionString);
    }

    /// <summary>
    /// Tests database connection
    /// </summary>
    public bool TestConnection()
    {
        try
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                return true;
            }
        }
        catch (Exception)
        {
            return false;
        }
    }

    #endregion

    #region Execute Methods

    /// <summary>
    /// Executes a stored procedure and returns a DataTable
    /// </summary>
    public DataTable ExecuteStoredProcedure(string procedureName, params SqlParameter[] parameters)
    {
        DataTable dt = new DataTable();

        try
        {
            using (SqlConnection conn = GetConnection())
            {
                using (SqlCommand cmd = new SqlCommand(procedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 60; // 60 seconds timeout

                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    conn.Open();
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }
            }
        }
        catch (SqlException ex)
        {
            Logger.LogError("DatabaseHelper.ExecuteStoredProcedure", ex);
            throw new ApplicationException($"Database error executing {procedureName}: {ex.Message}", ex);
        }

        return dt;
    }

    /// <summary>
    /// Executes a stored procedure and returns a DataSet (multiple result sets)
    /// </summary>
    public DataSet ExecuteStoredProcedureDataSet(string procedureName, params SqlParameter[] parameters)
    {
        DataSet ds = new DataSet();

        try
        {
            using (SqlConnection conn = GetConnection())
            {
                using (SqlCommand cmd = new SqlCommand(procedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 60;

                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    conn.Open();
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(ds);
                    }
                }
            }
        }
        catch (SqlException ex)
        {
            Logger.LogError("DatabaseHelper.ExecuteStoredProcedureDataSet", ex);
            throw new ApplicationException($"Database error executing {procedureName}: {ex.Message}", ex);
        }

        return ds;
    }

    /// <summary>
    /// Executes a stored procedure and returns a scalar value
    /// </summary>
    public object ExecuteScalar(string procedureName, params SqlParameter[] parameters)
    {
        try
        {
            using (SqlConnection conn = GetConnection())
            {
                using (SqlCommand cmd = new SqlCommand(procedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    conn.Open();
                    return cmd.ExecuteScalar();
                }
            }
        }
        catch (SqlException ex)
        {
            Logger.LogError("DatabaseHelper.ExecuteScalar", ex);
            throw new ApplicationException($"Database error executing {procedureName}: {ex.Message}", ex);
        }
    }

    /// <summary>
    /// Executes a stored procedure without returning results (INSERT, UPDATE, DELETE)
    /// </summary>
    public int ExecuteNonQuery(string procedureName, params SqlParameter[] parameters)
    {
        try
        {
            using (SqlConnection conn = GetConnection())
            {
                using (SqlCommand cmd = new SqlCommand(procedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    conn.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }
        catch (SqlException ex)
        {
            Logger.LogError("DatabaseHelper.ExecuteNonQuery", ex);
            throw new ApplicationException($"Database error executing {procedureName}: {ex.Message}", ex);
        }
    }

    /// <summary>
    /// Executes a stored procedure and returns the output parameter value
    /// </summary>
    public object ExecuteWithOutputParameter(string procedureName, string outputParameterName, SqlDbType outputType, params SqlParameter[] inputParameters)
    {
        try
        {
            using (SqlConnection conn = GetConnection())
            {
                using (SqlCommand cmd = new SqlCommand(procedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    if (inputParameters != null)
                    {
                        cmd.Parameters.AddRange(inputParameters);
                    }

                    // Add output parameter
                    SqlParameter outputParam = new SqlParameter(outputParameterName, outputType)
                    {
                        Direction = ParameterDirection.Output
                    };
                    cmd.Parameters.Add(outputParam);

                    conn.Open();
                    cmd.ExecuteNonQuery();

                    return outputParam.Value;
                }
            }
        }
        catch (SqlException ex)
        {
            Logger.LogError("DatabaseHelper.ExecuteWithOutputParameter", ex);
            throw new ApplicationException($"Database error executing {procedureName}: {ex.Message}", ex);
        }
    }

    #endregion

    #region Lookup Data Methods

    /// <summary>
    /// Gets all active departments
    /// </summary>
    public DataTable GetDepartments()
    {
        return ExecuteStoredProcedure("sp_GetDepartments");
    }

    /// <summary>
    /// Gets all active locations
    /// </summary>
    public DataTable GetLocations()
    {
        return ExecuteStoredProcedure("sp_GetLocations");
    }

    /// <summary>
    /// Gets all active categories
    /// </summary>
    public DataTable GetCategories()
    {
        return ExecuteStoredProcedure("sp_GetCategories");
    }

    /// <summary>
    /// Gets all active users, optionally filtered by role
    /// </summary>
    public DataTable GetUsers(string role = null)
    {
        SqlParameter[] parameters = null;

        if (!string.IsNullOrEmpty(role))
        {
            parameters = new SqlParameter[]
            {
                new SqlParameter("@Role", role)
            };
        }

        return ExecuteStoredProcedure("sp_GetUsers", parameters);
    }

    #endregion

    #region Helper Methods

    /// <summary>
    /// Creates a SQL parameter
    /// </summary>
    public SqlParameter CreateParameter(string name, object value)
    {
        return new SqlParameter(name, value ?? DBNull.Value);
    }

    /// <summary>
    /// Creates a SQL parameter with specific data type
    /// </summary>
    public SqlParameter CreateParameter(string name, SqlDbType type, object value)
    {
        SqlParameter param = new SqlParameter(name, type);
        param.Value = value ?? DBNull.Value;
        return param;
    }

    /// <summary>
    /// Safely converts DBNull to null for nullable types
    /// </summary>
    public static T GetValue<T>(object value)
    {
        if (value == DBNull.Value || value == null)
        {
            return default(T);
        }
        return (T)value;
    }

    /// <summary>
    /// Safely gets string value from DataRow
    /// </summary>
    public static string GetString(DataRow row, string columnName)
    {
        if (row.IsNull(columnName))
            return string.Empty;
        return row[columnName].ToString();
    }

    /// <summary>
    /// Safely gets int value from DataRow
    /// </summary>
    public static int GetInt(DataRow row, string columnName)
    {
        if (row.IsNull(columnName))
            return 0;
        return Convert.ToInt32(row[columnName]);
    }

    /// <summary>
    /// Safely gets DateTime value from DataRow
    /// </summary>
    public static DateTime? GetDateTime(DataRow row, string columnName)
    {
        if (row.IsNull(columnName))
            return null;
        return Convert.ToDateTime(row[columnName]);
    }

    /// <summary>
    /// Safely gets bool value from DataRow
    /// </summary>
    public static bool GetBool(DataRow row, string columnName)
    {
        if (row.IsNull(columnName))
            return false;
        return Convert.ToBoolean(row[columnName]);
    }

    /// <summary>
    /// Safely gets decimal value from DataRow
    /// </summary>
    public static decimal? GetDecimal(DataRow row, string columnName)
    {
        if (row.IsNull(columnName))
            return null;
        return Convert.ToDecimal(row[columnName]);
    }

    #endregion
}

/// <summary>
/// Simple logger class for error logging
/// </summary>
public static class Logger
{
    private static readonly string _logPath = System.Web.Hosting.HostingEnvironment.MapPath("~/App_Data/Logs/");

    /// <summary>
    /// Logs an error to file
    /// </summary>
    public static void LogError(string source, Exception ex)
    {
        try
        {
            // Ensure log directory exists
            if (!System.IO.Directory.Exists(_logPath))
            {
                System.IO.Directory.CreateDirectory(_logPath);
            }

            string logFile = System.IO.Path.Combine(_logPath, $"ErrorLog_{DateTime.Now:yyyyMMdd}.txt");
            string logMessage = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] {source}\n{ex.ToString()}\n{new string('-', 80)}\n";

            System.IO.File.AppendAllText(logFile, logMessage);
        }
        catch
        {
            // Fail silently if logging fails
        }
    }

    /// <summary>
    /// Logs an informational message
    /// </summary>
    public static void LogInfo(string source, string message)
    {
        try
        {
            if (!System.IO.Directory.Exists(_logPath))
            {
                System.IO.Directory.CreateDirectory(_logPath);
            }

            string logFile = System.IO.Path.Combine(_logPath, $"InfoLog_{DateTime.Now:yyyyMMdd}.txt");
            string logMessage = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] {source}: {message}\n";

            System.IO.File.AppendAllText(logFile, logMessage);
        }
        catch
        {
            // Fail silently if logging fails
        }
    }
}
