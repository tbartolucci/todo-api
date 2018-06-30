using System;
using System.IO;
using Amazon;
using Amazon.DynamoDBv2;
using Amazon.Runtime;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Swashbuckle.AspNetCore.Swagger;

namespace TodoApi
{
    public class Startup
    {      
        public Startup(IHostingEnvironment env)
        {
            var builder = new ConfigurationBuilder();
            builder.AddEnvironmentVariables();
            Configuration = builder.Build();
        }
        
        public IConfigurationRoot Configuration { get; }
        
        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {  
            services.AddSingleton<IConfigurationRoot>(Configuration);
            services.AddMvc();
            
            services.AddSwaggerGen(c => { c.SwaggerDoc("v1", new Info
            {
                Title = "Todo Api", 
                Version = "v1",
                Description = "A simple example .NET Core API"
            }); 
                var basePath = AppContext.BaseDirectory;
                var xmlPath = Path.Combine(basePath, "TodoApi.xml");
                c.IncludeXmlComments(xmlPath);
            });
            
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app)
        {
            app.UseSwagger();
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "Todo API v1");
            });
            
            app.UseMvc();
        }
    }
}
