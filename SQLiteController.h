//
//  SQLiteController.h
//
//  by Fernando J. Pinilla Barrena
//  fpinilla@synapse.es
//
//  Created by Synapse Asesores Informaticos, S.L. on 07/04/11.
//  Copyright 2011 Synapse Asesores Informaticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface SQLiteController : NSObject {
    sqlite3 *db;
	BOOL dbOpened;
    sqlite3_stmt *resultQuery2;
	NSMutableArray *datosTabla;
    NSMutableDictionary *datosColumna;
}

-(BOOL)openDatabaseAtPath:(NSString*)archivo;
-(NSMutableArray *)executeSelect:(NSString *)sentence;
-(void)executeQuery:(NSString *)sentence;
-(BOOL)bdAbierta;
-(void)createEditableCopyOfDatabaseIfNeeded:(NSString *)ruta;
-(void)optimizarBD;

@end
