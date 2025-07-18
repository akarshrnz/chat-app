import 'package:chatapp/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:chatapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chatapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:chatapp/features/home/data/datasources/chat_remote_data_source.dart';
import 'package:chatapp/features/home/data/datasources/mirroring_remote_data_source.dart';
import 'package:chatapp/features/home/data/datasources/product_remote_data_source.dart';
import 'package:chatapp/features/home/data/repositories/home_repository_impl.dart';
import 'package:chatapp/features/home/domain/repositories/home_repository.dart';
import 'package:chatapp/features/home/domain/usecases/home_usecases.dart';
import 'package:chatapp/features/home/presentation/bloc/home_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
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
      sl(),
    ),
  );
  sl.registerLazySingleton(
    () => ProductRemoteDataSource(
      sl(),
    ),
  );
  sl.registerLazySingleton(
    () => MirrorRemoteDataSource(
      sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<
    HomeRepository
  >(
    () => HomeRepositoryImpl(
      chatDataSource:
          sl<
            ChatRemoteDataSource
          >(),
      productDataSource:
          sl<
            ProductRemoteDataSource
          >(),
      mirrorDataSource:
          sl<
            MirrorRemoteDataSource
          >(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(
    () => HomeUseCases(
      sl(),
    ),
  );

  // Bloc
  sl.registerFactory(
    () => HomeBloc(
      useCases:
          sl<
            HomeUseCases
          >(),
      auth: sl(),
    ),
  );
}
