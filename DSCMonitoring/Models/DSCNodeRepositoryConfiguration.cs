using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.CodeAnalysis.Options;
using Microsoft.Extensions.Options;

namespace DSCMonitoring.Models
{
    public class DSCNodeRepositoryConfiguration
    {
        public string ConnectionString { get; set; }
    }
}
