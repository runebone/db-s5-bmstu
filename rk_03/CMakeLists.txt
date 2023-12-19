cmake_minimum_required(VERSION 3.12)

project(rk_03)

set(LIBS_DIR /nix/var/nix/profiles/per-user/human/profile/lib)
set(INCS_DIR /nix/var/nix/profiles/per-user/human/profile/include)

include_directories(
    ${INCS_DIR}
    /nix/store/4g26kjad3bg7fwl7xlhd0n27d1v8adhh-libpqxx-7.7.0/include
    /home/human/Code/include/boost_1_82_0
    )

link_directories(
    ${LIBS_DIR}
    /nix/store/4g26kjad3bg7fwl7xlhd0n27d1v8adhh-libpqxx-7.7.0/lib
    )

add_executable(main
    main.cpp
    )

target_link_libraries(main pqxx boost_system boost_thread)
