import 'package:chatapp/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:chatapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chatapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:chatapp/features/home/data/datasources/chat_remote_data_source.dart';
import 'package:chatapp/features/home/data/repositories/chat_repository_impl.dart';
import 'package:chatapp/features/home/domain/repositories/chat_repository.dart';
import 'package:chatapp/features/home/domain/usecases/chat_usecases.dart';
import 'package:chatapp/features/home/presentation/bloc/chat_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<
  void
>
init() async {
  // Firebase core dependencies
  sl.registerLazySingleton(
    () => FirebaseAuth.instance,
  );
  sl.registerLazySingleton(
    () => FirebaseFirestore.instance,
  );
  sl.registerLazySingleton(
    () => FirebaseDatabase.instance,
  );
    sl.registerLazySingleton(() => FirebaseStorage.instance);

// auth
  sl.registerLazySingleton(
    () => AuthRemoteDataSource(
      sl(),
      sl(),
    ),
  );

  // Repository

  sl.registerLazySingleton<
    AuthRepositoryInterface
  >(
    () => AuthRepository(
      sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(
    () => AuthUseCases(
      sl(),
    ),
  );

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      sl(),
    ),
  );

  // home
  // DataSources
  sl.registerLazySingleton(
    () => ChatRemoteDataSource(
      sl(),sl(),
    ),
  );
 
 

  // Repository
  sl.registerLazySingleton<
    ChatRepository
  >(
    () => ChatRepositoryImpl(

          sl<
            ChatRemoteDataSource
          >(),
    
      
    ),
  );

  // UseCases
  sl.registerLazySingleton(
    () => ChatUseCases(
      sl(),
    ),
  );

  // Bloc
  sl.registerFactory(
    () => ChatBloc(
   
          sl<
            ChatUseCases
          >(),

    ),
  );
}
