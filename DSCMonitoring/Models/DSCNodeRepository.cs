using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using DSCMonitoring.Models;
using Microsoft.Extensions.Options;

namespace DSCMonitoring.Models
{
    public interface IDSCNodeRepository
    {
        IEnumerable<DSCNode> GetAll();
        DSCNodeDetails GetByNodeName(string nodename);
    }

    public class DSCNodeRepository :IDSCNodeRepository
    {
        private string connectionString;

        public DSCNodeRepository(IOptions<DSCNodeRepositoryConfiguration> configuration)
        {
            connectionString = configuration.Value.ConnectionString;
        }

        public IDbConnection Connection
        {
            get
            {
                return new SqlConnection(connectionString);
            }
        }

        public IEnumerable<DSCNode> GetAll()
        {
            using (IDbConnection dbConnection = Connection)
            {
                dbConnection.Open();
                return dbConnection.Query<DSCNode>("SELECT * FROM dbo.vNodeStatusComplex;");
            }
        }

        public DSCNodeDetails GetByNodeName(string nodename)
        {
            using (IDbConnection dbConnection = Connection)
            {
                string sQuery = "SELECT * FROM dbo.vNodeStatusComplex"
                                + " WHERE NodeName = @NodeName";
                dbConnection.Open();
                return dbConnection.Query<DSCNodeDetails>(sQuery, new { NodeName = nodename }).FirstOrDefault();
            }
        }
    }
}
