import 'package:chatapp/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:chatapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chatapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:chatapp/features/chat/domain/usecases/get_online_status.dart';
import 'package:chatapp/features/chat/domain/usecases/mark_messages_read.dart';
import 'package:chatapp/features/chat/domain/usecases/send_message.dart';
import 'package:chatapp/features/chat/domain/usecases/set_typing_status.dart';
import 'package:chatapp/features/chat/domain/usecases/upload_file.dart';
import 'package:chatapp/features/user_list/data/repositories/user_repository_impl.dart';
import 'package:chatapp/features/user_list/domain/repositories/user_repository.dart';
import 'package:chatapp/features/user_list/domain/usecases/get_all_users_usecase.dart';
import 'package:chatapp/features/user_list/presentation/bloc/chat_list_bloc.dart';
import 'package:chatapp/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chatapp/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chatapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:chatapp/features/chat/domain/usecases/get_messages.dart';
import 'package:chatapp/features/chat/presentation/bloc/chat_detail_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<
  void
>
init() async {
    sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

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

  // caht list 
   // Repository
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());

  // UseCase
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));

  // BLoC
  sl.registerFactory(() => ChatListBloc(sl()));

  // home
 sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSource(
        firestore: sl(),
        supabase: sl(),
      ));

  // Repository
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(remote: sl()));

  // Usecases
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => UploadFile(sl()));
  sl.registerLazySingleton(() => SetTypingStatus(sl()));
  sl.registerLazySingleton(() => GetOnlineStatus(sl()));
  sl.registerLazySingleton(() => MarkMessagesRead(sl()));

  sl.registerFactory(() => ChatDetailBloc(
        getMessages: sl(),
        sendMessage: sl(),
        uploadFile: sl(),
        setTypingStatus: sl(),
        getOnlineStatus: sl(),
        markMessagesRead: sl(),
      ));
 
 


 
}
