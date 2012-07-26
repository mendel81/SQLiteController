//
//  SQLiteController.m
//  by Fernando J. Pinilla Barrena
//  fpinilla@synapse.es
//
//  Created by Synapse Asesores Informaticos, S.L. on 07/04/11.
//  Copyright 2011 Synapse Asesores Informaticos S.L. All rights reserved.
//

#import "SQLiteController.h"


@implementation SQLiteController

-(id)init{
    datosTabla=[[NSMutableArray alloc] init];
    [super init];
    return self; 
}


-(NSMutableArray *)executeSelect:(NSString *)sentence{
	// Variables para realizar la consulta
   // NSLog(@"------------- %@", sentence);
	const char* siguiente;
    sqlite3_stmt *resultQuery;
		// Ejecuta la consulta
    @try {

        if (  sqlite3_prepare_v2(db,[sentence cStringUsingEncoding:NSISOLatin1StringEncoding],[sentence length],&resultQuery,&siguiente) == SQLITE_OK ){
            int columnas,i;
 			// Recorre el resultado
			[datosTabla removeAllObjects];
            datosColumna = [[NSMutableDictionary alloc] init];
			
			while (sqlite3_step(resultQuery)==SQLITE_ROW){

                
                columnas=sqlite3_column_count(resultQuery);
                for (i=0;i<columnas;i++){
                    
                    if ( sqlite3_column_type (resultQuery, i) ==1) {//tipo integer
                        [datosColumna setObject:[NSNumber numberWithInt:sqlite3_column_int(resultQuery, i)] forKey: [NSString stringWithUTF8String:(char *) sqlite3_column_name(resultQuery ,i)]];
                //        NSLog(@"NombreKey %@, valor: %i",[NSString stringWithUTF8String:(char *) sqlite3_column_name(resultQuery ,i)], sqlite3_column_int(resultQuery, i));
                    }
                    if ( sqlite3_column_type (resultQuery, i) ==2){ //tipo float
                        [datosColumna setValue:[NSNumber numberWithFloat:sqlite3_column_double (resultQuery, i)] forKey: [NSString stringWithUTF8String:(char *) sqlite3_column_name(resultQuery ,i)]];
                 //        NSLog(@"NombreKey %@, valor: %f",[NSString stringWithUTF8String:(char *) sqlite3_column_name(resultQuery ,i)], sqlite3_column_double(resultQuery, i));
                    }
                    
                    if ( sqlite3_column_type (resultQuery, i) ==3){ //tipo text
                        [datosColumna setValue:[NSString stringWithUTF8String:(char *) sqlite3_column_text(resultQuery ,i)] forKey: [NSString stringWithUTF8String:(char *) sqlite3_column_name(resultQuery ,i)]];
                  //      NSLog(@"NombreKey %@, valor: %@",[NSString stringWithUTF8String:(char *) sqlite3_column_name(resultQuery ,i)], [NSString stringWithUTF8String:(char *) sqlite3_column_text(resultQuery ,i)]);
                    }
                    
                    if ( sqlite3_column_type (resultQuery, i) ==4) //tipo blob
                       // [datosColumna setValue:[NSNumber numberWithInt:sqlite3_column_int(resultQuery, i)] forKey: [NSString stringWithUTF8String:(char *) sqlite3_column_name(resultQuery ,i)]];
                    
                        if ( sqlite3_column_type (resultQuery, i) ==5){ //tipo null 
                        [datosColumna setValue:nil forKey: [NSString stringWithUTF8String:(char *) sqlite3_column_name(resultQuery ,i)]];
                    //        NSLog(@"NombreKey %@, valor: %@",[NSString stringWithUTF8String:(char *) sqlite3_column_name(resultQuery ,i)],nil);
                        }

                }
	//			[datosTabla addObject:[datosColumna copy]];
                [datosTabla addObject: [[[NSMutableDictionary alloc] initWithDictionary:datosColumna copyItems:NO ]autorelease]];
                
                [datosColumna removeAllObjects];
                              
			}
          //  for (int x=0; x<[datosTabla count]; x++){
                
              //  NSLog(@"datosTabla id: %i", [[[datosTabla objectAtIndex:x]objectForKey:@"id_ruta"]intValue]);
           // }
			//sqlite3_finalize(resultadoConsulta);//destruye la sentencia
           // sqlite3_clear_bindings(resultQuery);
            sqlite3_reset(resultQuery);

			
		} else {
            NSLog(@"error en sqlite3_prepare - %s", sqlite3_errmsg(db));
		}
        
    
        return (datosTabla);

    } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
    }
    return (datosTabla);

		
	// Cierra el archivo de base de datos
    
}


-(void)executeQuery:(NSString *)sentence{
	// Variables para realizar la consulta
    
	const char* siguiente;
    sqlite3_stmt *resultadoConsulta;

	// Verifica el tipo de consulta
    
    // Ejecuta la consulta
    @try {
    if ( sqlite3_prepare_v2(db,[sentence cStringUsingEncoding:NSISOLatin1StringEncoding ],[sentence length],&resultadoConsulta,&siguiente) == SQLITE_OK ){
        
        int success = sqlite3_step(resultadoConsulta);
        if (success == SQLITE_ERROR) {
            NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
            NSLog(@"error al hacer el query %s", sqlite3_errmsg(db));
        } else {
           // NSLog(@"ExecuteQuery: %@",sentence);
        }
        
        sqlite3_finalize(resultadoConsulta);
        
    } else {
        NSLog(@"error en sqlite3_prepare %s", sqlite3_errmsg(db));
        NSLog(@"error con sentencia query: %@",sentence);
    }
  
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
        
}



-(BOOL)openDatabaseAtPath:(NSString*)archivo {
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *path = [documentsDirectory stringByAppendingPathComponent:archivo];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	//comprobamos si el fichero existe
	if([fileManager fileExistsAtPath:path])
	{
		if(sqlite3_open([path UTF8String], &db) == SQLITE_OK)
		{
            //NSLog(@"Base de datos abierta en %@", path);
			dbOpened = YES;
			return YES;
		}
	}
   // NSLog(@"Base de datos no localizada en %@", path);
	return NO;
}

- (void)createEditableCopyOfDatabaseIfNeeded:(NSString *)ruta {
	
	BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSError *error;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:ruta];
	
	success = [fileManager fileExistsAtPath:writableDBPath];
	
	// Si ya existe el archivo, no lo crea -_-
	
	if (success) return;
	
	// Crea una copia del archivo en el dispositivo móvil
	
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:ruta];

	
	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	
	if (!success) {
		
		//NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		NSLog(@"Failed to create writable database file with message '%@'.", [error localizedDescription]);
	}

}

-(void)optimizarBD{
  //  sqlite_exec(db, "VACUUM;", 0, 0);
    sqlite3_exec(db, "VACUUM;", 0, 0, nil);
}

-(BOOL)bdAbierta{
    return dbOpened;
}

- (void)dealloc
{
    sqlite3_close(db);
    [datosColumna release];
    [datosTabla release];
    [super dealloc];
}
/*
-(void)release{

    [super dealloc];
}*/


@end
