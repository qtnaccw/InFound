import 'package:flutter/material.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/styles.dart';

class PostContainerShimmer extends StatelessWidget {
  PostContainerShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
      margin: EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(color: AppStyles.pureWhite, borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Row(
              children: [
                Container(
                    margin: EdgeInsets.only(right: 6),
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                Expanded(
                  child: Container(
                    height: 48,
                    padding: EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Flexible(
                                  child: Container(
                                      width: 100,
                                      height: 22,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                      clipBehavior: Clip.antiAlias,
                                      child: AppShimmerEffect(
                                          width: double.infinity, height: double.infinity, radius: 0))),
                              Padding(
                                  padding: EdgeInsets.only(left: 2),
                                  child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                      clipBehavior: Clip.antiAlias,
                                      child:
                                          AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Container(
                            width: 80,
                            height: 18,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                            clipBehavior: Clip.antiAlias,
                            child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                        clipBehavior: Clip.antiAlias,
                        child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
                Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                        clipBehavior: Clip.antiAlias,
                        child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)))
              ],
            ),
          ),
          Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8),
              margin: EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Container(
                      margin: EdgeInsets.only(right: 2),
                      width: 44,
                      height: 24,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                      clipBehavior: Clip.antiAlias,
                      child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                  Expanded(
                      child: Container(
                          width: double.infinity,
                          height: 26,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                          clipBehavior: Clip.antiAlias,
                          child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)))
                ],
              )),
          Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 8, right: 8, top: 12),
              child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
          // Container(
          //     width: double.infinity,
          //     padding: EdgeInsets.only(left: 24, right: 8, top: 12),
          //     child: Column(
          //       children: [
          //         Row(children: [
          //           Padding(
          //               padding: EdgeInsets.only(right: 4),
          //               child: Container(
          //                   width: 18,
          //                   height: 18,
          //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          //                   clipBehavior: Clip.antiAlias,
          //                   child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
          //           Padding(
          //               padding: EdgeInsets.only(right: 4),
          //               child: Container(
          //                   width: 70,
          //                   height: 18,
          //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          //                   clipBehavior: Clip.antiAlias,
          //                   child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
          //           Expanded(
          //               child: Container(
          //                   width: 80,
          //                   height: 18,
          //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          //                   clipBehavior: Clip.antiAlias,
          //                   child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)))
          //         ]),
          //         SizedBox(
          //           height: 4,
          //         ),
          //         Row(children: [
          //           Padding(
          //               padding: EdgeInsets.only(right: 4),
          //               child: Container(
          //                   width: 18,
          //                   height: 18,
          //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          //                   clipBehavior: Clip.antiAlias,
          //                   child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
          //           Padding(
          //               padding: EdgeInsets.only(right: 4),
          //               child: Container(
          //                   width: 70,
          //                   height: 18,
          //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          //                   clipBehavior: Clip.antiAlias,
          //                   child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
          //           Expanded(
          //               child: Container(
          //                   width: 80,
          //                   height: 18,
          //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          //                   clipBehavior: Clip.antiAlias,
          //                   child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)))
          //         ]),
          //         SizedBox(
          //           height: 4,
          //         ),
          //         Row(children: [
          //           Padding(
          //               padding: EdgeInsets.only(right: 4),
          //               child: Container(
          //                   width: 18,
          //                   height: 18,
          //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          //                   clipBehavior: Clip.antiAlias,
          //                   child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
          //           Padding(
          //               padding: EdgeInsets.only(right: 4),
          //               child: Container(
          //                   width: 70,
          //                   height: 18,
          //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          //                   clipBehavior: Clip.antiAlias,
          //                   child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
          //           Expanded(
          //               child: Container(
          //                   width: 80,
          //                   height: 18,
          //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          //                   clipBehavior: Clip.antiAlias,
          //                   child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)))
          //         ]),
          //       ],
          //     )),
          // Container(
          //   width: double.infinity,
          //   child: LayoutBuilder(builder: (context, cnst) {
          //     return Container(
          //         width: double.infinity,
          //         height: (cnst.maxWidth - 16) / 3,
          //         padding: EdgeInsets.symmetric(horizontal: 8),
          //         margin: EdgeInsets.only(top: 12),
          //         child: Row(
          //           children: [
          //             Expanded(
          //                 child: Container(
          //                     width: double.infinity,
          //                     height: double.infinity,
          //                     decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          //                     clipBehavior: Clip.antiAlias,
          //                     child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
          //             SizedBox(
          //               width: 8,
          //             ),
          //             Expanded(
          //                 child: Container(
          //                     width: double.infinity,
          //                     height: double.infinity,
          //                     decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          //                     clipBehavior: Clip.antiAlias,
          //                     child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
          //             SizedBox(
          //               width: 8,
          //             ),
          //             Expanded(
          //                 child: Container(
          //                     width: double.infinity,
          //                     height: double.infinity,
          //                     decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          //                     clipBehavior: Clip.antiAlias,
          //                     child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)))
          //           ],
          //         ));
          //   }),
          // ),
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Divider(
              color: AppStyles.lightGrey,
            ),
          ),
          Container(
            height: 36,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Container(
                              width: 56,
                              height: 36,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                              clipBehavior: Clip.antiAlias,
                              child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
                      Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Container(
                              width: 56,
                              height: 36,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                              clipBehavior: Clip.antiAlias,
                              child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                        clipBehavior: Clip.antiAlias,
                        child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentWidgetContainerShimmer extends StatelessWidget {
  const CommentWidgetContainerShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.only(right: 6),
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppStyles.pureWhite,
                  boxShadow: [AppStyles().lightBoxShadow(AppStyles.primaryBlack.withAlpha(150))],
                ),
                alignment: Alignment.center,
                child: Container(
                    height: 28,
                    width: 28,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 30,
                    margin: EdgeInsets.only(
                      top: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                    height: 25,
                                    width: 110,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2, right: 4),
                                child: Container(
                                    height: 22,
                                    width: 22,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                              ),
                              Flexible(
                                child: Container(
                                    height: 25,
                                    width: 100,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                              clipBehavior: Clip.antiAlias,
                              child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 4),
                    width: double.infinity,
                    child: Container(
                        height: 70,
                        width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                  ),
                  Container(
                    height: 30,
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 4, bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Container(
                                    height: 25,
                                    width: 50,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Container(
                                    height: 25,
                                    width: 70,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Container(
                                    height: 25,
                                    width: 100,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReplyWidgetContainerShimmer extends StatelessWidget {
  const ReplyWidgetContainerShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.only(right: 6),
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppStyles.pureWhite,
                  boxShadow: [AppStyles().lightBoxShadow(AppStyles.primaryBlack.withAlpha(150))],
                ),
                alignment: Alignment.center,
                child: Container(
                    height: 28,
                    width: 28,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 30,
                    margin: EdgeInsets.only(
                      top: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                    height: 25,
                                    width: 110,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2, right: 4),
                                child: Container(
                                    height: 22,
                                    width: 22,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                              ),
                              Flexible(
                                child: Container(
                                    height: 25,
                                    width: 100,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                              clipBehavior: Clip.antiAlias,
                              child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 4),
                    width: double.infinity,
                    child: Container(
                        height: 70,
                        width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                  ),
                  Container(
                    height: 30,
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 4, bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Container(
                                    height: 25,
                                    width: 50,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Container(
                                    height: 25,
                                    width: 70,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportContainerShimmer extends StatelessWidget {
  ReportContainerShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
      margin: EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(color: AppStyles.pureWhite, borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Row(
              children: [
                Container(
                    margin: EdgeInsets.only(right: 6),
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                Expanded(
                  child: Container(
                    height: 48,
                    padding: EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Flexible(
                                  child: Container(
                                      width: 100,
                                      height: 22,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                      clipBehavior: Clip.antiAlias,
                                      child: AppShimmerEffect(
                                          width: double.infinity, height: double.infinity, radius: 0))),
                              Padding(
                                  padding: EdgeInsets.only(left: 2),
                                  child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                      clipBehavior: Clip.antiAlias,
                                      child:
                                          AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Container(
                            width: 80,
                            height: 18,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                            clipBehavior: Clip.antiAlias,
                            child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                        clipBehavior: Clip.antiAlias,
                        child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
                Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                        clipBehavior: Clip.antiAlias,
                        child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)))
              ],
            ),
          ),
          Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8),
              margin: EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Container(
                      margin: EdgeInsets.only(right: 2),
                      width: 44,
                      height: 24,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                      clipBehavior: Clip.antiAlias,
                      child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)),
                  Expanded(
                      child: Container(
                          width: double.infinity,
                          height: 26,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                          clipBehavior: Clip.antiAlias,
                          child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0)))
                ],
              )),
          Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 8, right: 8, top: 12),
              child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: AppShimmerEffect(width: double.infinity, height: double.infinity, radius: 0))),
        ],
      ),
    );
  }
}
